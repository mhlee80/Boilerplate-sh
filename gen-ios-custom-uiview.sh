usage="usage: $0 <projectName> <author> <viewName>";

if [ $1 ] ; then 
  projectName=$1;
fi

if [ $2 ] ; then 
  author=$2;
fi

if [ $3 ] ; then 
  viewName=$3;
fi

if [ -z $projectName ] ; then
  echo $usage; exit 1;
fi

if [ -z $author ] ; then
  echo $usage; exit 1;
fi

if [ -z $viewName ] ; then
  echo $usage; exit 1;
fi

nowDate=$(date +%Y-%m-%d)
nowYear=$(date +%Y)

echo """\
//
//  $viewName.swift
//  $viewName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

class $viewName: UIView {    
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  convenience init() {
    self.init(frame: .zero)
  }
}""" > $viewName.swift;

exit 0;
