extends StaticBody2D

# Две честные страницы воспоминаний о Cougar
const INSPECT_PAGES = [
	"Пошарпанное игровое кресло от известной фирмы.",
	"Столько тёплых (и не очень) воспоминаний с ним!"
]

# Игрок сам вызовет эту функцию по кнопке E
func interact() -> Array:
	return INSPECT_PAGES
