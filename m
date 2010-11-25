From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Thu, 25 Nov 2010 11:04:16 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1011251049350.3051@takamine.ncl.cs.columbia.edu>
References: <4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
 <20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org>
 <20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org>
 <4CE69B8C.6050606@cs.columbia.edu> <Pine.LNX.4.64.1011201312470.15662@takamine.ncl.cs.columbia.edu>
 <4CE8228C.3000108@kernel.org> <20101121081853.GA21672@sundance.ccs.neu.edu>
 <20101121082143.GB21672@sundance.ccs.neu.edu>
 <Pine.LNX.4.64.1011231234410.11731@takamine.ncl.cs.columbia.edu>
 <AANLkTinXZ-xO0h7DPB7YrdWhDBNmWM7jg74XT9bWrshK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="998262290-1606244456-1290701056=:3051"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinXZ-xO0h7DPB7YrdWhDBNmWM7jg74XT9bWrshK@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Kapil Arya <kapil@ccs.neu.edu>
Cc: Gene Cooperman <gene@ccs.neu.edu>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, xemul@sw.ru, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--998262290-1606244456-1290701056=:3051
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 23 Nov 2010, Kapil Arya wrote:

> OL> Even if it did - the question is not how to deal with "glue"
> OL> (you demonstrated quite well how to do that with DMTCP), but
> OL> how should teh basic, core c/r functionality work - which is
> OL> below, and orthogonal to the "glue".
> 
> There seems to be an implicit assumption that it is easy to separate the DMTCP
> "glue code" from the DMTCP C/R engine as separate modules. DMTCP is modular but
> it splits the problems into modules along a different line than Linux C/R. We
> look forward to the joint experiment in which we would try to combine DMTCP
> with Linux C/R. This will help answer the question in our mind.

I apologize for being blunt - but this is probably an issue specific to 
DMTCP's engineering...

> In order to explore the issue, let's imagine that we have a successful merge of
> DMTCP and Linux C/R. The following are some user-space glue issues. It's not
> obvious to us how the merged software will handle these issues.
> 
> 1. Sockets -- DMTCP handles all sockets in a common manner through a single
> module. Sockets are checkpointed independently of whether they are local or
> remote. In a merger of DMTCP and Linux C/R, what does Linux C/R do when it sees
> remote sockets? Or should DMTCP take down all remote sockets before
> checkpointing? If DMTCP has to do this, it would be less efficient than the
> current design which keeps the remote sockets connections alive during
> checkpoint.

What is a "local" socket ?  af_unix, or locally connected af_inet ?

Anyway, with linux-cr you'd do what's needed after the restarted tasks are
created, but before their state is restored. For each such "old" socket
that you want to replace, you'd create (in userspace with arbitrary glue" 
code!) a new socket, and use this socket when restoring the state of the
task. Similarly, you could replace any other resource, not only sockets.

> 
> 2. XLib and X11-server -- Consider checkpointing a single X11 app without the
> X11-server and without VNC. This is something we intend to add to DMTCP in the
> next few months. We have already mapped out the design in our minds. An X11
> application includes the Xlib library. The data of an X11 window is, by
> default, contained in the X11 library -- not in the X11-server. The application
> communicates with the X11-server using socket connections, which would be
> considered a leak by Linux C/R. At restart time, DMTCP will ask the
> X11-server to create a bare window and then make the appropriate Xlib call to
> repaint the window based on the data stored in the Xlib  library.
> For checkpoint/resume, the window stays up and does not has to be repainted.
> How will the combined DMTCP/Linux C/R work? Will DMTCP have to take
> down the window prior to Linux C/R and paint a new window at resume time?
> Doesn't this add inefficiency?

Repainting during restart is the least of your problems.

Leak detection is not a problem: 
If the socket connects out of the containers (like af_inet) - then it is 
not a leak, andyou treat it as described above.
If the sockets connects within the container but you don't checkpoint the
"peer" process - then it is not a container-c/r (in which case you don't 
look for leaks).

Also, the application could mark resources to not be checkpointed (e.g. 
scratch memory to save storage, or sockets to not count as leaks).

I don't see any problem with X11 or any other library and "glue".

> 
> 3. Checkpointing a single process (e.g. a bash shell) talking to an xterm via
> a pty -- We assume that from the viewpoint of Linux C/R a pty is a leak since
> there is a second process operating the master end of the pty. In this
> case we are
> guessing that Linux C/R would checkpoint and restart without the gurantees of
> reliability. We are guessing that Linux C/R would not save and restore the pty,
> instead it would be the responsibility of DMTCP to restore the current settings
> of the pty (e.g. packet mode vs. regular mode). Is our understanding correct?
> Would this work?

I explain again - in case it wasn't clear from my 3-part post: leak 
detection is relevant _only_ for full container-c/r. It doesn't make 
sense otherwise.

If you want to checkpoint individual components of an application,
then it's up to userspace to produce/provide the relevant "glue" to
make it "make sense" when those components restart without their 
original eco-system.

Thanks,

Oren.
--998262290-1606244456-1290701056=:3051--
