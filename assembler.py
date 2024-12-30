
r_type_opcode = 0b110000

r_type_func_lookup = {
    'xor': 0b0000,
    'sll': 0b0001,
    'srl': 0b0010,
    'nor': 0b0011,
    'sub': 0b0100,
    'or': 0b0101,
    'and': 0b0110,
    'add': 0b0111,
    'slt': 0b1000,
}

i_type_opcode_lookup = {
        'lw': 0b110001,
        'sw': 0b110010,
        'beq': 0b110011,
        'bne': 0b110100,
        'addi': 0b110101,
        'jalfor': 0b111000,
}

j_type_opcode_lookup = {
        'j': 0b110110,
        'jal': 0b110111,
}


def assemble_r_type(instruction):
    opcode = r_type_opcode
    func = r_type_func_lookup[instruction[0]]
    registers = instruction[1].split(',')
    registers = [register.strip() for register in registers]
    if len(registers) != 3:
        raise ValueError(f'Invalid number of registers for instruction {instruction[0]}')

    register_pos = 1
    if registers[0][1] == 'r':
        register_pos = 2
    rd = int(registers[0][register_pos])

    register_pos = 1
    if registers[1][1] == 'r':
        register_pos = 2
    rt = int(registers[1][register_pos])

    if func in [0b0001, 0b0010]:
        rs = int(registers[2])
    else:
        register_pos = 1
        if registers[2][1] == 'r':
            register_pos = 2
        rs = int(registers[2][register_pos])

    return (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (func << 0)

def assemble_i_type(instruction):
    #FIXME test lw, sw with data for example;
    # lw r1, 10($r2)
    opcode = i_type_opcode_lookup[instruction[0]]
    registers = instruction[1].split(',')


    if instruction[0] in ['lw', 'sw']:
        registers = [registers[0], registers[1].split('(')[1].split(')')[0], registers[1].split('(')[0]]

    registers = [register.strip() for register in registers]


    register_pos = 1
    if registers[0][1] == 'r':
        register_pos = 2
    rt = int(registers[0][register_pos])

    register_pos = 1
    if registers[1][1] == 'r':
        register_pos = 2
    rs = int(registers[1][register_pos])

    imm = int(registers[2], 16)

    return (opcode << 26) | (rs << 21) | (rt << 16) | imm

def assemble_j_type(instruction):
    opcode = j_type_opcode_lookup[instruction[0]]
    imm = int(instruction[1], 16)

    return (opcode << 26) | imm

def assemble_instruction(instruction):
    print(instruction)
    if instruction[0] in r_type_func_lookup:
        return assemble_r_type(instruction)
    elif instruction[0] in i_type_opcode_lookup:
        return assemble_i_type(instruction)
    elif instruction[0] in j_type_opcode_lookup:
        return assemble_j_type(instruction)
    else:
        raise ValueError(f'Invalid instruction {instruction[0]}')

if __name__ == "__main__":
    import sys
    import re
    import argparse

    parser = argparse.ArgumentParser(description='Assembler for the MIPS processor')
    parser.add_argument('input', type=str, help='Input file')
    #parser.add_argument('output', type=str, help='Output file')
    args = parser.parse_args()

    with open(args.input, 'r') as f:
        lines = f.readlines()
        instructions = [line.strip().split(' ', 1) for line in lines]
        instructions_list = [assemble_instruction(instruction) for instruction in instructions]
        hex_instructions = [hex(int(instruction)) for instruction in instructions_list]
        bianry_instructions = [bin(int(instruction)) for instruction in instructions_list]

    print(instructions)
    print(instructions_list)
    print(hex_instructions)
    print(bianry_instructions)
    

