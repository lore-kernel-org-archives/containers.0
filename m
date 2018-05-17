From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [PATCH v2 3/4] seccomp: add a way to get a listener fd from ptrace
Date: Thu, 17 May 2018 09:59:32 -0600
Message-ID: <20180517155932.GC3831__36652.8308055878$1526572677$gmane$org@cisco>
References: <20180517151218.12850-1-tycho@tycho.ws>
	<20180517151218.12850-4-tycho@tycho.ws>
	<20180517154139.GB8586@redhat.com> <20180517155733.GB3831@cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180517155733.GB3831@cisco>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 17, 2018 at 09:57:33AM -0600, Tycho Andersen wrote:
> On Thu, May 17, 2018 at 05:41:39PM +0200, Oleg Nesterov wrote:
> > and since init_listener() does __get_seccomp_filter() on sucess, it is needed
> > uncondtitionally?
> 
> I think there does need to be a __get_seccomp_filter() on success in
> init_listener(), because it's paired with the __put_seccomp_filter in
> seccomp_notify_release. The listener fd has a reference to the filter,
> and that shouldn't go away until after the fd is freed.

Oh, sorry. I see what you meant here. Yes, it should be unconditional.

Tycho
