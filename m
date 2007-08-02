From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/15] Signal semantics
Date: Thu, 2 Aug 2007 15:09:39 -0500
Message-ID: <20070802200939.GA13386@sergelap.austin.ibm.com>
References: <46A8B37B.6050108@openvz.org> <46A8B5C7.9040407@openvz.org>
	<20070727123153.GA92@tv-sign.ru> <46A9F54B.5050000@openvz.org>
	<20070727184604.GB1072@us.ibm.com>
	<20070727195943.GA25878@sergelap.austin.ibm.com>
	<46ADB000.1000705@openvz.org>
	<20070801161335.GA10747@sergelap.austin.ibm.com>
	<46B19754.4050908@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46B19754.4050908-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Kirill Korotaev (dev-3ImXcnM4P+0@public.gmane.org):
> Serge E. Hallyn wrote:
> > Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> > 
> >>[snip]
> >>
> >>
> >>>>| Maybe it's worth disabling cross-namespaces ptracing...
> >>>>
> >>>>I think so too. Its probably not a serious limitation ?
> >>>
> >>>Several people think we will implement 'namespace entering' through a
> >>>ptrace hack, where maybe the admin ptraces the init in a child pidns,
> >>
> >>Why not implement namespace entering w/o any hacks? :)
> > 
> > 
> > I did, as a patch on top of the nsproxy container subsystem.  The
> > response was that that is a hack, and ptrace is cleaner  :)
> > 
> > So the current options for namespace entering would be:
> > 
> > 	* using Cedric's bind_ns() functionality, which assigns an
> > 	  integer global id to a namespace, and allows a process to
> > 	  enter a namespace by that global id
> 
> looks more or less good and what OVZ actually does.
> So I would prefer this one.

I think this was Cedric's last post of it:

https://lists.linux-foundation.org/pipermail/containers/2007-June/005665.html

However I'm pretty sure Eric would be soundly against this.

> > 	* using my nsproxy container subsystem patch, which lets
> > 	  a process enter another namespace using
> > 	  	echo pid > /container/some/cont/directory/tasks
> > 	  and eventually might allow construction of custom
> > 	  namespaces, i.e.
> > 	  	mkdir /container/c1/c2
> > 		ln -s /container/c1/c1/network /container/c1/c2/network
> > 		echo $$ > /container/c1/c2/tasks
> 
> Sound ok and logical as well.

I last posted this here:
http://www.mail-archive.com/devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org/msg00295.html
In the ensuing thread, the ptrace-based solution is also discussed.

> > 	* using ptrace to coerce a process in the target namespace
> > 	  into forking and executing the desired program.
> 
> you'll need to change ptrace interface in this case imho...
> doesn't sound ok at all... at least for me. So I agree with Pavel.

Well maybe the problem is that while I think of it as ptrace-based, it's
really only like ptrace in that it hijacks another process for a moment
to clone it, but it likely will end up a completely different system
call.

Eric, just curious, have you worked on this at all since february?

-serge
