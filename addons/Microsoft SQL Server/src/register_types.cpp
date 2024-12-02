#include <godot_cpp/core/class_db.hpp> 
#include <godot_cpp/godot.hpp>
#include "sql_connection.h" 

using namespace godot;

void initialize_sql_extension(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return; 
    }

    ClassDB::register_class<SQLConnection>();
}

void uninitialize_sql_extension(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
GDExtensionBool GDE_EXPORT sql_library_init(const GDExtensionInterface *p_interface,
                                            GDExtensionClassLibraryPtr p_library,
                                            GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_interface, p_library, r_initialization);

    init_obj.register_initializer(initialize_sql_extension);
    init_obj.register_terminator(uninitialize_sql_extension);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
