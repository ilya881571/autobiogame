extends StaticBody2D

const INSPECT_PAGES = [
	"Рабочий стол, заваленный хламом и всякими бухгалтерскими и программистскими штучками.",
	"Именно здесь создаются шедевры.",
	"Вы видите записку. Взять её?",
	"\"ctrl + shift + esc - диспетчер задач\""
]

func interact() -> Dictionary:
	return {
		"pages": INSPECT_PAGES,
		"has_choice": true,
		"choice_at_page": 2, # Кнопки вылезут ровно на слайде "Взять её?" (индекс 2)
		"text_true": "Взять",
		"text_false": "Оставить"
	}
