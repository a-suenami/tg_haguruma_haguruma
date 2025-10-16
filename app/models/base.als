module base

// UUID型の定義
sig UUID {}

// Timestamp型の定義
sig Timestamp {}

// ステータスの定義
abstract sig Status {}
one sig Draft, Preview, Published, Unpublished extends Status {}

// フィールド型の定義
abstract sig FieldType {}
one sig TextType, RichTextType, MediaType extends FieldType {}