const std = @import("std");
const allocator = std.heap.page_allocator;
const zant = @import("../../../zant.zig");

// --- onnx ---
const onnx = zant.onnx;
const ModelProto = onnx.ModelProto;
const GraphProto = onnx.GraphProto;
const NodeProto = onnx.NodeProto;
const TensorProto = onnx.TensorProto;

// --- zant ---
const tensorZant = @import("../../tensorZant.zig");
const TensorZant = tensorZant.TensorZant;
const tensorMath = zant.core.tensor.math_standard;
const utils = @import("../../../CodeGen/utils.zig");

// https://onnx.ai/onnx/operators/onnx__Ceil.html
// INPUTS:
//      - X (heterogeneous) - T: Input tensor
// OUTPUTS:
//      - Y (heterogeneous) - T: Output tensor with ceiling of input elements
pub const Ceil = struct {
    input_X: *TensorZant,
    output_Y: *TensorZant,

    pub fn init(nodeProto: *NodeProto) !Ceil {
        const input_X = if (tensorZant.tensorMap.getPtr(nodeProto.input[0])) |ptr| ptr else return error.input_X_notFound;
        const output_Y = if (tensorZant.tensorMap.getPtr(nodeProto.output[0])) |ptr| ptr else return error.output_Y_notFound;

        return Ceil{
            .input_X = input_X,
            .output_Y = output_Y,
        };
    }

    pub fn get_output_shape(self: Ceil) []usize { // TODO
        const res: []usize = [_]usize{ 0, 0, 1, 1 };
        res[0] += self.input;
        return res;
    }

    pub fn compute_output_shape(self: Ceil) []usize {
        return try tensorMath.get_ceil_output_shape(self.input_X.get_shape());
    }

    pub fn print(self: Ceil) void { // TODO
        std.debug.print("\n Ceil:\n {any}", .{self});
    }
};
