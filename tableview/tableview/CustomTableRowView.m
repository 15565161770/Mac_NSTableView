//
//  CustomTableRowView.m
//  tableview
//
//  Created by 仝兴伟 on 2017/5/12.
//  Copyright © 2017年 仝兴伟. All rights reserved.
//  表格颜色选中定制

#import "CustomTableRowView.h"

@implementation CustomTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 1, 1);

        [[NSColor colorWithWhite:0.9 alpha:1]setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:selectionRect];
        [path fill];
        [path stroke];
    }
}

@end
