//
//  AppDelegate.m
//  tableview
//
//  Created by 仝兴伟 on 2017/5/12.
//  Copyright © 2017年 仝兴伟. All rights reserved.
//  代码创建tableview

#import "AppDelegate.h"
#import "Masonry.h"
#import "CustomTableRowView.h"

@interface AppDelegate ()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSTableView *tableview;
@property (nonatomic, strong) NSScrollView *tableviewScrollView;
@property (nonatomic, strong) NSArray *datas;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self addData];
    
    [self addTable];
}


#pragma mark -- 数据源
- (void)addData {
    self.datas = @[
                   @{@"name":@"john",@"address":@"USA"},
                   @{@"name":@"mary",@"address":@"China"},
                   @{@"name":@"park",@"address":@"Japan"},
                   @{@"name":@"Daba",@"address":@"Russia"},
                   
                   ];
}

#pragma mark -- tableview
- (void)addTable {
    // 创建表格
    self.tableview = [[NSTableView alloc]init];
    [self.tableview setAutoresizesSubviews:YES];
    [self.tableview setFocusRingType:(NSFocusRingTypeNone)];
    // 创建单元格
    NSTableColumn *column1 = [[NSTableColumn alloc]initWithIdentifier:@"name"];
    column1.title = @"name";
    [self.tableview addTableColumn:column1];
    
    NSTableColumn *column2 = [[NSTableColumn alloc]initWithIdentifier:@"address"];
    column2.title = @"address";
    [self.tableview addTableColumn:column2];
    
    // 表格双击事件
    self.tableview.doubleAction = @selector(doubleAction:);
    
    // 数据拖放
    [self.tableview registerForDraggedTypes:[NSArray arrayWithObject:@"myTableViewDragDataTypeName"]];
    
    // 设置代理
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    // 创建滚动条
    self.tableviewScrollView = [[NSScrollView alloc]init];
    [self.tableviewScrollView setHasVerticalScroller:NO];
    [self.tableviewScrollView setHasHorizontalScroller:NO];
    [self.tableviewScrollView setFocusRingType:NSFocusRingTypeNone];
    [self.tableviewScrollView setAutohidesScrollers:YES];
    [self.tableviewScrollView setBorderType:NSBezelBorder];
    [self.tableviewScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // 设置滚动条的内容视图为 tableview
    [self.tableviewScrollView setDocumentView:self.tableview];
    
    // 增加到父视图
    [self.window.contentView addSubview:self.tableviewScrollView];
    
    // 使用masony 做autolayout布局设置
    [self.tableviewScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window.contentView.mas_top).with.offset(0);
        make.bottom.equalTo(self.window.contentView.mas_bottom).with.offset(-24);
        make.left.equalTo(self.window.contentView.mas_left).with.offset(0);
        make.right.equalTo(self.window.contentView.mas_right).with.offset(0);
    }];
    
}


#pragma mark -- nstableviewdelagate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // 获取row数据
    NSDictionary *data = self.datas[row];
    // 表格列的标识
    NSString *identifier = tableColumn.identifier;
    // 单元格数据
    NSString *value = data[identifier];
    // 更换表格列的标识，创建但愿视图
    NSView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    
    NSTextField *textField;
    // 如果不存在，创建新的textField
    if (!view) {
        textField = [[NSTextField alloc]init];
        [textField setBezeled:NO];
        [textField setDrawsBackground:NO];
        [textField setEditable:NO];
        textField.identifier = identifier;
        view = textField;
    } else {
        textField = (NSTextField *)view;
    }
    
    if (value) {
        // 更新单元格的文本
        textField.stringValue = value;
    }
    return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.datas.count;
}

// 自定义cell背景
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    CustomTableRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (rowView == nil) {
        rowView = [[CustomTableRowView alloc]init];
        rowView.identifier = @"rowView";
    }
    return rowView;
    
}

#pragma mark -- 双击事件
- (void)doubleAction:(id)sender {
    NSTableView *tableview = sender;
    NSLog(@"%ld", (long)tableview.selectedRow);
//    NSLog(@"douleAcion --- %ld", self.tableview.selectedRow);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"当前是-%ld-行", self.tableview.selectedRow);
    
    // 当点击的时候 会出现数据排序
    for (NSTableColumn *tableColumn in self.tableview.tableColumns) {
        NSSortDescriptor *sortStates = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:NO comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if (obj1 < obj2){
                return NSOrderedAscending;
            }
            if (obj1 > obj2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
                
        }];
        [tableColumn setSortDescriptorPrototype:sortStates];
    }
    
}

#pragma mark -- 实现拖拽方法
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    // copy the row numbers to the pasteboard
    NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:@"myTableViewDragDataTypeName"] owner:self];
    [pboard setData:zNSIndexSetData forType:@"myTableViewDragDataTypeName"];
    return YES;
}

// 拖放结束后，从剪切板对象获取拖放的drafRow
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *rowData = [pboard dataForType:@"myTableViewDragDataTypeName"];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rowIndexes firstIndex];
    NSLog(@"%ld", dragRow);
    // 拖放的源 dragRow 拖放的目标row这2个参数有了之后，就可以对表的数据源数组做dragRow和目标row交换然后重新加载reload
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
