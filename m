From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC 2/3] seccomp: hoist out filter resolving logic
Date: Tue, 13 Feb 2018 13:29:23 -0800
Message-ID: <CAGXu5jJLCcmB6MCeOgMntUgrnPycbmM8MBt_CVGXtsrQ+mtf=Q__40480.2333134741$1518557276$gmane$org@mail.gmail.com>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180204104946.25559-3-tycho@tycho.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180204104946.25559-3-tycho-E0fblnxP3wo@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Feb 4, 2018 at 2:49 AM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> Hoist out the nth filter resolving logic that ptrace uses into a new
> function. We'll use this in the next patch to implement the new
> PTRACE_SECCOMP_GET_FILTER_FLAGS command. This is based on an older patch
> that I had sent a while ago; it significantly revamps the get_nth_filter
> logic based on previous suggestions from Oleg.

Is this the same as f06eae831f0c1fc5b982ea200daf552810e1dd55 ? Quick
compare says yes? Either way, please rebase to v4.16-rc1 (or -rc2 in
the future). :)

-Kees

-- 
Kees Cook
Pixel Security
