local ReplicatedStorage = game:GetService("ReplicatedStorage")
local options = {
    biomes = {"ugf"}
}

return {
    options = options;
    current = {
        biome = "ugf";
        socket_direction = nil;
        socket_category = nil;
        socket_type = "wall";
    }
}