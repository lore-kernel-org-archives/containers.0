From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v8][PATCH 3/10]: Make pid_max a pid_ns property
Date: Tue, 13 Oct 2009 11:28:18 -0500
Message-ID: <20091013162818.GA13416__33237.2949495495$1255453790$gmane$org@us.ibm.com>
References: <20091013044925.GA28181@us.ibm.com>
	<20091013045041.GC28435@us.ibm.com> <4AD47C1F.7040703@openvz.org>
	<20091013152453.GA9994@us.ibm.com> <4AD4A676.3010603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AD4A676.3010603-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> > This patch isn't a core part of the clone_with_pid functionality,
> > just something Eric has asked for.  So I don't object to dropping
> > it.  But I disagree with Alexey's claim that this isn't a namespace
> > property.  It should be.
> 
> OK
> 
> >> frankly I don't see the reason for doing so. Why should we?
> >> Especially taking into account, that we essentially cannot
> >> change thin in the namespace level 3 and deeper?
> > 
> > What do you mean by that?  With this patchset we're not, it's
> > true, but we trivially can - even now, userspace can simply not
> > give the container CAP_SYS_ADMIN or write access to the sysctl
> > so they can't do any more CLONE_NEWPIDS or change the sysctl.
> 
> It's a misprint - I meant "level 2 and deeper". Sysctl is
> only pointing at the init_pid_ns variable.

Right, and I'm saying that's to be fixed up as with all other
containerized sysctl's.  You're right that this patch doesn't
solve that problem, but you seem to be arguing that it bc it's
not done in this patch, we should act as though it can't be
done.

But again, maybe we're best off dropping this patch (sorry, Suka,
I had suggested you add it...) and focusing on the rest of the set
for now.

thanks,
-serge
