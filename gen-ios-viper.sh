usage="usage: $0 <projectName> <author> <moduleName>";

if [ $1 ] ; then 
  projectName=$1;
fi

if [ $2 ] ; then 
  author=$2;
fi

if [ $3 ] ; then 
  moduleName=$3;
fi

if [ -z $projectName ] ; then
  echo $usage; exit 1;
fi

if [ -z $author ] ; then
  echo $usage; exit 1;
fi

if [ -z $moduleName ] ; then
  echo $usage; exit 1;
fi

nowDate=$(date +%Y-%m-%d)
nowYear=$(date +%Y)

protocolsName="$moduleName"Protocols

wireframeProtocolName="$moduleName"WireframeProtocol
viewProtocolName="$moduleName"ViewProtocol
presenterProtocolName="$moduleName"PresenterProtocol
interactorProtocolName="$moduleName"InteractorProtocol

wireframeName="$moduleName"Wireframe
viewName="$moduleName"View
presenterName="$moduleName"Presenter
interactorName="$moduleName"Interactor

echo """\
//
//  $protocolsName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

protocol $wireframeProtocolName: class {
  static func createModule() -> $viewProtocolName 
}

protocol $viewProtocolName: class {
  var presenter: $presenterProtocolName? { get set }
}

protocol $presenterProtocolName: class {
  var view: $viewProtocolName? { get set }
  var interactor: $interactorProtocolName? { get set }
  var wireframe: $wireframeProtocolName? { get set }
  
  func viewDidLoad()
}

protocol $interactorProtocolName: class {
}""" > $protocolsName.swift;


echo """\
//
//  $wireframeName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

class $wireframeName: NSObject, $wireframeProtocolName {
  static func createModule() -> $viewProtocolName {
    let view = $viewName()
    let presenter = $presenterName()
    let interactor = $interactorName()
    let wireframe = $wireframeName()
    
    view.presenter = presenter
    presenter.view = view
    presenter.interactor = interactor
    presenter.wireframe = wireframe
    
    return view
  }
  
}""" > $wireframeName.swift

echo """\
//
//  $viewName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation
import UIKit

class $viewName: UIViewController, $viewProtocolName {  
  var presenter: $presenterProtocolName? {
    didSet {
      setupBind()
    }
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
        
    DispatchQueue.main.async { [weak self] in
      self?.presenter?.viewDidLoad()
    }
  }
  
  private func setupBind() {
  }
}""" > $viewName.swift;

echo """\
//
//  $presenterName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

class $presenterName: NSObject, $presenterProtocolName {
  weak var view: $viewProtocolName?
  var interactor: $interactorProtocolName?
  var wireframe: $wireframeProtocolName?
    
  func viewDidLoad() {
  }
}""" > $presenterName.swift;

echo """\
//
//  $interactorName.swift
//  $projectName
//
//  Created by $author on $nowDate.
//  Copyright © $nowYear $author. All rights reserved.
//

import Foundation

class $interactorName: NSObject, $interactorProtocolName {
}""" > $interactorName.swift;

exit 0;
