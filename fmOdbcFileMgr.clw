   member('fmOdbcDemo')

   map
   end

! --------------------------------------------------
! fill a queue using the typcial file manager access
! --------------------------------------------------
fileFill procedure(fileMgrODBC fmOdbc)

retv   byte,auto

  code

  fmOdbc.open()
  fmOdbc.useFile()
  buffer(fmOdbc.file, 20)
  set(labelDemo)

  loop
    if (fm.next() = level:Benign)
      demoQueue.sysId = labelDemo.Sysid
      demoQueue.Label = labelDemo.Label
      demoQueue.amount = labelDemo.amount
      add(demoQueue)
    else 
      break;
    end
  end

  fmOdbc.close()

  return
! end fileFill -----------------------------------------------

! --------------------------------------------------
! fill a queue using a prop:sql statement 
! --------------------------------------------------
propSqlFill procedure()

retv   byte,auto

  code

  open(labeldemo)
  !buffer(labeldemo, 1000)
  labeldemo{prop:sql} = 'select ld.SysId, ld.Label, ld.amount from dbo.LabelDemo ld order by ld.testCol desc'
  
  loop
     next(labeldemo)
     if (errorcode() > 0)
      break
    end
    demoQueue.sysId = labelDemo.Sysid
    demoQueue.Label = labelDemo.Label
    demoQueue.amount = labelDemo.amount
    add(demoQueue)
  end

  close(labeldemo)

  return
! end propSqlFill -----------------------------------------------
