//
//  ViewController.m
//  sqlite3_study
//
//  Created by wdw on 2020/5/23.
//  Copyright © 2020 wdw. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()

@end

@implementation ViewController
{
//    sqlite3 *db;
}

static sqlite3 *db = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateData];
}

//删除数据
- (void)deleteData {
    db = [self openSqlDataBase];
    //sql语句
    const char *deleteSql = "delete from t_students where name = '王小二-30'";
    int deleteResult = sqlite3_exec(db, deleteSql, NULL, NULL, NULL);
    if (deleteResult == SQLITE_OK) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败-%d", deleteResult);
    }
    [self closeDB];
}

//修改数据
- (void)updateData {
    db = [self openSqlDataBase];
    
    //sql语句
    const char *changeSql = "update t_students set age = 'wdw' where name = '王小二-30'";
    char *errMsg = NULL;
    int updateResult = sqlite3_exec(db, changeSql, NULL, NULL, &errMsg);

    if (updateResult == SQLITE_OK) {
        NSLog(@"修改成功");
    } else {
        NSLog(@"修改失败,%d", updateResult);
    }
    
    [self closeDB];
}

//查询操作
- (void)queryData
{
    db = [self openSqlDataBase];
    //sql语句
    const char *sql = "SELECT id,name,age FROM t_students WHERE age < 10";
    sqlite3_stmt *stmt = NULL;

    if (sqlite3_prepare(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        NSLog(@"sql语句没有问题");

        //每调用一次sqlite3_step函数,stmt就会指向下一条记录
        while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
            //去除数据
            int ID = sqlite3_column_int(stmt, 0);//取出第0列的值
            const unsigned char *name = sqlite3_column_text(stmt, 1);//取出第1列字段的值
            int age = sqlite3_column_int(stmt, 2);//取出第2列字段的值
            printf("[%d]-[%s]-[%d]\n", ID, name, age);
        }

        //释放跟随指针
        sqlite3_finalize(stmt);
    } else {
        NSLog(@"查询语句有问题");
        sqlite3_finalize(stmt);
    }
    [self closeDB];
}

//插入收据
- (void)insertData
{
    db = [self openSqlDataBase];

    for (int i = 0; i < 20; i++) {
        NSString *name = [NSString stringWithFormat:@"王二小-%d", arc4random_uniform(100)];
        int age = arc4random_uniform(20) + 1;

        //拼接sql语句
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_students (name,age) VALUES ('%@',%d);", name, age];
        char *errMsg = NULL;
        int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, &errMsg);

        if (result == SQLITE_OK) {
            NSLog(@"插入数据成功-%@", name);
        } else {
            NSLog(@"插入数据失败-%s", errMsg);
        }
    }

    [self closeDB];
}

//打开数据库
- (sqlite3 *)openSqlDataBase {
    if (db != nil) {
        return db;
    }

    //获取数据库文件的路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [docPath stringByAppendingPathComponent:@"student.sqlite"];
    NSLog(@"fileName = %@", fileName);
    //将oc字符串转换为c语言的字符串
    const char *cFileName = fileName.UTF8String;
    //打开数据库文件(如果数据库文件不存在,那么该函数会自动创建数据库文件)
    int result = sqlite3_open(cFileName, &db);

    if (result == SQLITE_OK) {
        NSLog(@"成功打开数据库");
    } else {
        NSLog(@"打开数据库失败");
    }

    return db;
}

//关闭数据库
- (void)closeDB
{
    int result = sqlite3_close(db);

    if (result ==  SQLITE_OK) {
        db = nil;
        NSLog(@"关闭数据库成功");
    } else {
        NSLog(@"关闭数据库失败");
    }
}

//创建数据库
- (void)createTable {
    //打开数据库
    db = [self openSqlDataBase];

    //创建表
    const char *sql = "CREATE TABLE IF NOT EXISTS t_students (id integer PRIMARY KEY AUTOINCREMENT,name text NOT NULL,age integer NOT NULL);";
    char *errMsg = NULL;

    int result = sqlite3_exec(db, sql, NULL, NULL, &errMsg);
    if (result == SQLITE_OK) {
        NSLog(@"创建表成功");
    } else {
        NSLog(@"创建表失败");
        printf("创表失败-%s-%s-%s", __FILE__, __FILE__, errMsg);
    }

    //关闭数据库
    [self closeDB];
}

@end
