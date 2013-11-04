From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Mon, 4 Nov 2013 21:51:35 +0000
Message-ID: <20131104215135.GA26190@mail.hallyn.com>
References: <20130723181606.GA6342@sergelap>
	<20130723183018.GF21100@mtj.dyndns.org> <20130723183841.GA9021@tp>
	<CAOS58YPynQ-QBx5nZEnYrP5kGTVvv9VAj0cV0aYeikTitvTQbA@mail.gmail.com>
	<20130723190426.GA9577@tp> <20130723191245.GI21100@mtj.dyndns.org>
	<20130723192801.GA9923@tp>
	<CAOS58YPEKtEiZWsn-8u6OPr-UsyQp=XR+ecGmXyOdT0JnYAmsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YPEKtEiZWsn-8u6OPr-UsyQp=XR+ecGmXyOdT0JnYAmsA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hello, Serge.
> 
> On Tue, Jul 23, 2013 at 3:28 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Tue, Jul 23, 2013 at 02:04:26PM -0500, Serge Hallyn wrote:
> > > If task A is uid 1000 on the host, and creates task B as uid X in a new
> > > user namespace, then task A, still being uid 1000 on the host, is
> > > privileged with respect to B and his namespace - i.e.
> > > ns_capable(B->userns, CAP_SYS_ADMIN) is true.
> 
> >> Well, that also is the exact type of priv delegation we're moving away
> >> from, so....
> >
> > I think that's unreasonable, but I guess I'll have to go reread the
> > old thread.
> 
> Yeah, please do. I think the case is pretty strong for disallowing
> delegation of cgroup directories to !root (or whatever CAP it should
> be) users. It's inherently unsafe for some controllers and ends up
> leaking kernel implementation details into regular binaries thus
> cementing those leaked details as APIs, which is a giant no-no.

Hi Tejun,

So to come back to this...  At plumbers, I believe you were not present
at the 'let me contain that for you' session.  There the "delegation is
not safe" topic came up.  When pressed, the only example that came up
was (IIRC) having to do with an rt scheduling issue which, all agreed,
was a bug in the implementation which should be fixed, rather than a valid
reason to say that delegation of cgroups should be fundamentally not supported.

Do you have a list of such issues which you see with delegation?  That is,
cases where, if ownership of a subtree is granted to a non-root user,
that user can affect tasks owned by other users who are in other
cgroups?

-serge
