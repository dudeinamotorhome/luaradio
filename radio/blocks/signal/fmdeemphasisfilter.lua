local ffi = require('ffi')

local block = require('radio.core.block')
local types = require('radio.types')
local filter_utils = require('radio.blocks.signal.filter_utils')

local IIRFilterBlock = require('radio.blocks.signal.iirfilter').IIRFilterBlock

local FMDeemphasisFilterBlock = block.factory("FMDeemphasisFilterBlock", IIRFilterBlock)

function FMDeemphasisFilterBlock:instantiate(tau)
    IIRFilterBlock.instantiate(self, types.Float32Type.vector(2), types.Float32Type.vector(2))

    self.tau = tau
end

function FMDeemphasisFilterBlock:initialize()
    --[[
        Single-pole low pass filter transfer function:
            H(s) = 1/(tau*s + 1)

        Bilinear transformed transfer function:
            H(z) = (1 + z^-1) / ((1 + 2*tau/T) + (1 - 2*tau/T)*z^-1)

        Divided through for a[0] = 1:
            H(z) = ( (1/(1 + 2*tau/T)) + (1/(1 + 2*tau/T))*z^-1 ) / (1 + ((1 - 2*tau/T)/(1 + 2*tau/T))*z^-1)

        b_taps = { 1/(1 + 2*tau/T), 1/(1 + 2*tau/T) }
        a_taps = { 1, ((1 - 2*tau/T)/(1 + 2*tau/T)) }
    ]]--

    -- Populate taps
    self.b_taps.data[0].value = 1/(1 + 2*self.tau*self:get_rate())
    self.b_taps.data[1].value = 1/(1 + 2*self.tau*self:get_rate())
    self.a_taps.data[0].value = 1
    self.a_taps.data[1].value = (1 - 2*self.tau*self:get_rate())/(1 + 2*self.tau*self:get_rate())

    IIRFilterBlock.initialize(self)
end

return {FMDeemphasisFilterBlock = FMDeemphasisFilterBlock}
