From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Thoughts on tightening up user namespace creation
Date: Tue, 8 Mar 2016 16:41:16 -0600
Message-ID: <20160308224116.GA17693@mail.hallyn.com>
References: <CALCETrU4+zTKABz1foEA=an3XYbe_UXxn_w9=1GjVzMe5DXXPw@mail.gmail.com>
	<20160308060657.GA3565@mail.hallyn.com>
	<CALCETrUx_O7Uiyxjs8H++bAR34dSvWny+HsVzXasCVE9wHFGFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrUx_O7Uiyxjs8H++bAR34dSvWny+HsVzXasCVE9wHFGFA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> On Mar 7, 2016 10:06 PM, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > On Mon, Mar 07, 2016 at 09:15:25PM -0800, Andy Lutomirski wrote:
> > >  - Ubuntu requires CAP_SYS_ADMIN
> >
> > No, it does not.  It has temporarily re-added a sysctl which can enable
> > that behavior, but it's not set by default.  The reason for providing it
> > is not a distrust of user namespaces in general, but because we're enabling
> > some bleeding edge patches which haven't been accepted upstream yet.  Once
> > they're accepted upstream I expect that patch to be dropped again, unless
> > it has gone upstream.
> >
> > Debian does afaik still have a version of a patch I'd originally written
> > before user namespaces were upstream which defaulted unprivileged userns
> > cloning to off.  Did you mean Debian here?
> 
> I meant Ubuntu 14.04, which I tested, possibly poorly.

Weird, 14.04 with the default kernel (3.13.0-79-generic #123-Ubuntu)
doesn't have the sysctl at all.

-serge
