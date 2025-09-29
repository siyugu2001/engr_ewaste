package info;

public class item {
	public String name;
	public String parts;
	public String place;
	public item(String name,String parts,String place) {
		 this.name = name;
	     this.parts = parts;
	     this.place=place;
	}
	public void setname(String name) {
		this.name = name;
	}
	public String getname() {
		return name;
	}
	public void setparts(String parts) {
		this.parts = parts;
	}
	public String getparts() {
		return parts;
   }
	public void setplace(String place) {
		this.place = place;
	}
	public String getplace() {
		return place;
   }
}
