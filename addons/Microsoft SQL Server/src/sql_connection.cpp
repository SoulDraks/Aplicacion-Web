#include "sql_connection.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

SQLConnection::SQLConnection() 
{
    SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &sql_env_handle);
    SQLSetEnvAttr(sql_env_handle, SQL_ATTR_ODBC_VERSION, (void *)SQL_OV_ODBC3, 0);
    SQLAllocHandle(SQL_HANDLE_DBC, sql_env_handle, &sql_connection_handle);
}

SQLConnection::~SQLConnection() 
{
    SQLFreeHandle(SQL_HANDLE_DBC, sql_connection_handle);
    SQLFreeHandle(SQL_HANDLE_ENV, sql_env_handle);
}

bool SQLConnection::connect_to_database(const String &server, const String &database, const String &user, const String &password) 
{
    String conn_str = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=" + server + ";DATABASE=" + database + ";UID=" + user + ";PWD=" + password + ";";
    SQLCHAR ret_conn_str[1024];
    SQLRETURN ret = SQLDriverConnect(sql_connection_handle, NULL, (SQLCHAR *)conn_str.utf8().get_data(), SQL_NTS, ret_conn_str, 1024, NULL, SQL_DRIVER_NOPROMPT);
    return (ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO);
}

bool SQLConnection::execute_query(const String &query) 
{
    SQLAllocHandle(SQL_HANDLE_STMT, sql_connection_handle, &sql_statement_handle);
    SQLRETURN ret = SQLExecDirect(sql_statement_handle, (SQLCHAR *)query.utf8().get_data(), SQL_NTS);
    SQLFreeHandle(SQL_HANDLE_STMT, sql_statement_handle);
    return (ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO);
}

Dictionary SQLConnection::select_rows(const String &query) 
{
    Dictionary result;
    Array rows;

    SQLAllocHandle(SQL_HANDLE_STMT, sql_connection_handle, &sql_statement_handle);
    SQLExecDirect(sql_statement_handle, (SQLCHAR *)query.utf8().get_data(), SQL_NTS);

    SQLCHAR column_data[256];
    SQLINTEGER column_len;

    while (SQLFetch(sql_statement_handle) == SQL_SUCCESS) {
        Array row;
        int column_index = 1;

        while (SQLGetData(sql_statement_handle, column_index, SQL_C_CHAR, column_data, sizeof(column_data), &column_len) == SQL_SUCCESS) {
            row.append(String((char *)column_data));
            column_index++;
        }

        rows.append(row);
    }

    result["rows"] = rows;
    SQLFreeHandle(SQL_HANDLE_STMT, sql_statement_handle);

    return result;
}

void SQLConnection::_bind_methods() {
    ClassDB::bind_method(D_METHOD("connect_to_database", "server", "database", "user", "password"), &SQLConnection::connect_to_database);
    ClassDB::bind_method(D_METHOD("execute_query", "query"), &SQLConnection::execute_query);
    ClassDB::bind_method(D_METHOD("select_rows", "query"), &SQLConnection::select_rows);
}
