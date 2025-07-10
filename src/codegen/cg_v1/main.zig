const std = @import("std");
const zant = @import("zant");
const onnx = zant.onnx;
const ModelOnnx = onnx.ModelProto;

const IR_zant = @import("IR_zant");
const IR_graph = IR_zant.IR_graph;
const IR_codegen = @import("codegen_v1.zig");
const codegen_options = @import("codegen_v1.zig").codegen_options;

const codeGen_tests = IR_codegen.testWriter;

// called by "zig build IR_codegen" optionals:" -Dlog -Dmodel="name" -D ..." see build.zig"
pub fn main_v1(model: ModelOnnx) !void {

    //generate the inference library
    try IR_codegen.codegnenerateFromOnnx(codegen_options.model, codegen_options.generated_path, model);

    // Test the generated code
    try codeGen_tests.writeTestFile(codegen_options.model, codegen_options.generated_path);
}
