   member('fmOdbcDemo')

   map
   end

! --------------------------------------------------
! fill a queue using the typcial file manager access
! --------------------------------------------------
fileFill procedure(fileMgrODBC fmOdbc)

retv   byte,auto

  code

  free(demoQueue)
  fmOdbc.open()
  fmOdbc.useFile()

  set(labelDemo)

  loop
    if (fm.next() <> level:Benign)
      break
    end
    demoQueue.sysId = labelDemo.Sysid
    demoQueue.Label = labelDemo.Label
    demoQueue.amount = labelDemo.amount
    add(demoQueue)
  end

  fmOdbc.close()

  return
! end fileFill -----------------------------------------------

! --------------------------------------------------
! fill a queue using the typcial file manager access
! --------------------------------------------------
propSqlFill procedure()

retv   byte,auto

  code

  free(demoQueue)

  open(labeldemo)
  set(labeldemo)
  labeldemo{prop:sql} = 'select ld.SysId, ld.Label, ld.amount from dbo.LabelDemo ld order by ld.Label desc'
  stop(fileerror())
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
