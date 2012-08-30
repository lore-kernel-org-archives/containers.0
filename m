From: "Muralidhar, Rajeev D" <rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: Error compiling CRtools-0.1..
Date: Thu, 30 Aug 2012 07:15:35 +0000
Message-ID: <604C0E70D2B64644B0BCE6939D9F7D0327E011@BGSMSX102.gar.corp.intel.com>
References: <604C0E70D2B64644B0BCE6939D9F7D0327A1C6@BGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <604C0E70D2B64644B0BCE6939D9F7D0327A1C6-yHIBzpp8AekFyVwBAnZdSLfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

OK I could fix all compilation issues by moving to a x86_64 OS and having t=
he following packages (it would be good to update the wiki page, I can prov=
ide the detailed steps I had to take to the owner, pls let me know)

			=A7 Sudo apt-get install libprotobuf-dev
			=A7 Sudo apt-get install libprotoc-dev
			=A7 sudo apt-get install protobuf-c-compiler
			=A7 sudo apt-get install libprotobuf-c0
			=A7 sudo apt-get install libprotobuf-c0-dev

Now, when trying to test crtools, I get the following error:

$ ./crtools check
Error (sk-unix.c: 283): Can't stat socket 12547 (./var/run/sdp): Bad file d=
escriptor

And a whole bunch of such errors.

What might the problem be? Am I missing some netlink library? I have instal=
led libnetlink, libnl, libnl-dev.

Thanks
Rajeev

-----Original Message-----
From: Muralidhar, Rajeev D =

Sent: Tuesday, August 28, 2012 4:40 PM
To: Muralidhar, Rajeev D; Serge Hallyn
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Subject: Error compiling CRtools-0.1..

OK it seems like one error was that =


#include "restorer.h" =


Was missing from syscall-common-x86-64., which has the definition of rcx.

Now I can proceed one step further in compilation, but I get these errors:

In file included from ./include/types.h:7,
                 from ./include/restorer.h:8,
                 from syscall-common-x86-64.S:2,
                 from syscall-x86-64.S:3:
./include/bitops.h:50:3: error: #error x86-32 is not implemented yet In fil=
e included from ./include/restorer.h:8,
                 from syscall-common-x86-64.S:2,
                 from syscall-x86-64.S:3:
./include/types.h:180:3: error: #error x86-32 bit mode not yet implemented =
In file included from ./include/syscall.h:4,
                 from ./include/lock.h:11,
                 from ./include/restorer.h:10,
                 from syscall-common-x86-64.S:2,
                 from syscall-x86-64.S:3:
./include/syscall-types.h:17:3: error: #error x86-32 bit mode not yet imple=
mented In file included from syscall-common-x86-64.S:2,
                 from syscall-x86-64.S:3:
./include/restorer.h:20:3: error: #error Only x86-64 is supported

I have a Core i5 laptop, running Ubuntu 10.04. uname -m shows "i686". =


Does this mean that CR tools will run only on x86_64, but will never work o=
n 32-bit systems? (Isnt Intel x86_64 is backward compatible with 32-bit?)

Thanks for your help in advance. =

Rajeev


-----Original Message-----
From: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org [mailto:containers-boun=
ces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org] On Behalf Of Muralidhar, Rajeev D
Sent: Tuesday, August 28, 2012 2:12 PM
To: Serge Hallyn
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Subject: RE: Linux C/R: VNC server/Xterm checkpoint/recovery

I forgot to mention that I am doing on this on a Ubuntu 10.04, and uname -a=
 shows "i686"

Thanks
Rajeev


-----Original Message-----
From: Muralidhar, Rajeev D
Sent: Tuesday, August 28, 2012 1:56 PM
To: Serge Hallyn
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; Muralidhar, Rajeev D
Subject: RE: Linux C/R: VNC server/Xterm checkpoint/recovery

Hi all,

I got started with the information on http://criu.org/Main_Page =


I installed the linux-cr.git tree, compiled & have that ready. =


For CR-tools, I got all the required packages, but I am not able to compile=
 crtools. This is the error I am seeing. Can someone pls let me know why I =
am getting this error?

rdmurali@ubuntu:~/Linux-CR/crtools$ make
  PROTOBUF inventory.pb-c.c
  CC       inventory.pb-c.o
  PROTOBUF fdinfo.pb-c.c
  CC       fdinfo.pb-c.o
  PROTOBUF fown.pb-c.c
  CC       fown.pb-c.o
  PROTOBUF regfile.pb-c.c
  CC       regfile.pb-c.o
  PROTOBUF ghost-file.pb-c.c
  CC       ghost-file.pb-c.o
  PROTOBUF fifo.pb-c.c
  CC       fifo.pb-c.o
  PROTOBUF remap-file-path.pb-c.c
  CC       remap-file-path.pb-c.o
  PROTOBUF eventfd.pb-c.c
  CC       eventfd.pb-c.o
  PROTOBUF eventpoll.pb-c.c
  CC       eventpoll.pb-c.o
  PROTOBUF fh.pb-c.c
  CC       fh.pb-c.o
  PROTOBUF inotify.pb-c.c
  CC       inotify.pb-c.o
  PROTOBUF signalfd.pb-c.c
  CC       signalfd.pb-c.o
  PROTOBUF fs.pb-c.c
  CC       fs.pb-c.o
  PROTOBUF pstree.pb-c.c
  CC       pstree.pb-c.o
  PROTOBUF pipe.pb-c.c
  CC       pipe.pb-c.o
  PROTOBUF tcp-stream.pb-c.c
  CC       tcp-stream.pb-c.o
  PROTOBUF sk-packet.pb-c.c
  CC       sk-packet.pb-c.o
  PROTOBUF mnt.pb-c.c
  CC       mnt.pb-c.o
  PROTOBUF pipe-data.pb-c.c
  CC       pipe-data.pb-c.o
  PROTOBUF sa.pb-c.c
  CC       sa.pb-c.o
  PROTOBUF itimer.pb-c.c
  CC       itimer.pb-c.o
  PROTOBUF mm.pb-c.c
  CC       mm.pb-c.o
  PROTOBUF sk-opts.pb-c.c
  CC       sk-opts.pb-c.o
  PROTOBUF sk-unix.pb-c.c
  CC       sk-unix.pb-c.o
  PROTOBUF sk-inet.pb-c.c
  CC       sk-inet.pb-c.o
  PROTOBUF packet-sock.pb-c.c
  CC       packet-sock.pb-c.o
packet-sock.pb-c.c: In function 'packet_sock_entry__init':
packet-sock.pb-c.c:98: warning: this decimal constant is unsigned only in I=
SO C90
packet-sock.pb-c.c: At top level:
packet-sock.pb-c.c:318: warning: this decimal constant is unsigned only in =
ISO C90
  PROTOBUF ipc-var.pb-c.c
  CC       ipc-var.pb-c.o
  PROTOBUF ipc-desc.pb-c.c
  CC       ipc-desc.pb-c.o
  PROTOBUF ipc-shm.pb-c.c
  CC       ipc-shm.pb-c.o
  PROTOBUF ipc-msg.pb-c.c
  CC       ipc-msg.pb-c.o
  PROTOBUF ipc-sem.pb-c.c
  CC       ipc-sem.pb-c.o
  PROTOBUF utsns.pb-c.c
  CC       utsns.pb-c.o
  PROTOBUF creds.pb-c.c
  CC       creds.pb-c.o
  PROTOBUF vma.pb-c.c
  CC       vma.pb-c.o
  PROTOBUF core.pb-c.c
  CC       core.pb-c.o
  PROTOBUF netdev.pb-c.c
  CC       netdev.pb-c.o
  LINK     protobuf-lib.o
  GEN      syscall-x86-64.S
  CC       syscall-x86-64.o
syscall-common-x86-64.S: Assembler messages:
syscall-common-x86-64.S:13: Error: bad register name `%rcx'
make[1]: *** [syscall-x86-64.o] Error 1
make: *** [pie] Error 2


thanks
Rajeev

-----Original Message-----
From: Serge Hallyn [mailto:serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org]
Sent: Tuesday, August 21, 2012 3:04 AM
To: Muralidhar, Rajeev D
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Subject: Re: Linux C/R: VNC server/Xterm checkpoint/recovery

See http://criu.org/Main_Page

Quoting Muralidhar, Rajeev D (rajeev.d.muralidhar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org):
> Hi,
> =

> Any help on this? =

> =

> Thanks
> Rajeev
> =

> =

> -----Original Message-----
> From: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org =

> [mailto:containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org] On Behalf Of =

> Muralidhar, Rajeev D
> Sent: Tuesday, August 14, 2012 4:00 PM
> To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Subject: Linux C/R: VNC server/Xterm checkpoint/recovery
> =

> HI all,
> =

> I am a newbie to Linux C/R. Can someone please tell me if I can checkpoin=
t and restart VNC sessions with Linux C/R? what is the easiest way to test =
this out? Also, if the VNC session was running Xterms, will they be restore=
d with Linux C/R? =

> =

> Thanks,
> Rajeev
> =

> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
