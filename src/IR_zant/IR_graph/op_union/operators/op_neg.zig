const std = @import("std");
const allocator = std.heap.page_allocator;
const zant = @import("zant");
const IR_zant = @import("../../../IR_zant.zig");

// --- onnx ---
const onnx = zant.onnx;
const ModelProto = onnx.ModelProto;
const GraphProto = onnx.GraphProto;
const NodeProto = onnx.NodeProto;
const TensorProto = onnx.TensorProto;

// --- zant ---
const tensorZant_lib = IR_zant.IR_graph.tensorZant_lib;
const TensorZant = tensorZant_lib.TensorZant;
const TensorCategory = tensorZant_lib.TensorCategory;

const tensorMath = zant.core.tensor.math_standard;

const utils = IR_zant.IR_codegen.utils;

// https://onnx.ai/onnx/operators/onnx__Neg.html#l-onnx-doc-neg
// INPUTS:
//      - X (heterogeneous) - T:  input tensor.
// OUTPUTS:
//      - Y (heterogeneous) - T:  output tensor.

pub const Neg = struct {
    input_X: *TensorZant,
    output_Y: *TensorZant,

    pub fn init(nodeProto: *NodeProto) !Neg {
        const input_X = if (tensorZant_lib.tensorMap.getPtr(nodeProto.input[0])) |ptr| ptr else return error.input_X_notFound;
        const output_Y = if (tensorZant_lib.tensorMap.getPtr(nodeProto.output[0])) |ptr| ptr else return error.output_Y_notFound;

        //set the output type:
        if (output_Y.ty == tensorZant_lib.TensorType.undefined) output_Y.ty = input_X.ty;

        return Neg{
            .input_X = input_X,
            .output_Y = output_Y,
        };
    }

    pub fn get_output_shape(self: Neg) []usize {
        return self.output_Y.getShape();
    }

    pub fn get_output_tensor(self: Neg) *TensorZant {
        return self.output_Y;
    }

    pub fn write_op(self: Neg, writer: std.fs.File.Writer) !void {
        // Create input tensor string
        var input_tensor_string: []u8 = undefined;
        defer allocator.free(input_tensor_string);

        if (self.input_X.tc == TensorCategory.INITIALIZER) {
            input_tensor_string = try std.mem.concat(allocator, u8, &[_][]const u8{
                "@constCast(&param_lib.tensor_",
                try utils.getSanitizedName(self.input_X.name),
                ")",
            });
        } else {
            input_tensor_string = try std.mem.concat(allocator, u8, &[_][]const u8{ "&tensor_", try utils.getSanitizedName(self.input_X.name) });
        }

        _ = try writer.print(
            \\
            \\
            \\    tensMath.neg_lean({s}, {s}, &tensor_{s})
        , .{
            self.input_X.ty.toString(),
            input_tensor_string,
            try utils.getSanitizedName(self.output_Y.name),
        });
    }

    pub fn compute_output_shape(self: Neg) []usize {
        var output_shape: []usize = undefined;
        output_shape = try tensorMath.get_neg_output_shape(self.input_X.shape);
        self.output_Y.shape = output_shape;
        return output_shape;
    }

    pub fn print(self: Neg) void {
        std.debug.print("\n Neg:\n {any}", .{self});
    }
};
