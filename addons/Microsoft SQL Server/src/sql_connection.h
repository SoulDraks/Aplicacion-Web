#include <godot_cpp/classes/node.hpp> 
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <sql.h>
#include <sqlext.h>

namespace godot {

class SQLConnection : public Node { 
    GDCLASS(SQLConnection, Node);

private:
    SQLHANDLE sql_env_handle = SQL_NULL_HANDLE;
    SQLHANDLE sql_connection_handle = SQL_NULL_HANDLE;
    SQLHANDLE sql_statement_handle = SQL_NULL_HANDLE;
public:
    SQLConnection();
    ~SQLConnection();

    bool connect_to_database(const String &server, const String &database, const String &user, const String &password);
    bool execute_query(const String &query);
    Dictionary select_rows(const String &query); 

    static void _bind_methods();
};

}
