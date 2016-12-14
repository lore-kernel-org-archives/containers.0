From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCHv3] inotify: Convert to using per-namespace limits
Date: Thu, 15 Dec 2016 11:29:06 +1300
Message-ID: <87eg1a2lhp.fsf@xmission.com>
References: <87oa0fpsqs.fsf@xmission.com>
	<1481723793-6756-1-git-send-email-n.borisov.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1481723793-6756-1-git-send-email-n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
	(Nikolay Borisov's message of "Wed, 14 Dec 2016 15:56:33 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> This patchset converts inotify to using the newly introduced
> per-userns sysctl infrastructure.
>
> Currently the inotify instances/watches are being accounted in the
> user_struct structure. This means that in setups where multiple
> users in unprivileged containers map to the same underlying
> real user (i.e. pointing to the same user_struct) the inotify limits
> are going to be shared as well, allowing one user(or application) to exhaust
> all others limits.
>
> Fix this by switching the inotify sysctls to using the
> per-namespace/per-user limits. This will allow the server admin to
> set sensible global limits, which can further be tuned inside every
> individual user namespace. Additionally, in order to preserve the
> sysctl ABI make the existing inotify instances/watches sysctls
> modify the values of the initial user namespace.
>
> Signed-off-by: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
> Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> ---
>
> Okay, so here is another version, which should 
> hopefully be free of slab corruptions. There was an issue
> where in ucount.c the ifdef was checking the CONFIG_INOTIFY_USER_
> (pay attention to the trailing _, this was clearly a mistake). This 
> led to the user_table (and all duplicated from it tables) to not 
> contain the inotify-related members. In my local testing I got 
> kasan splats even during kernel boot, due to out-of-bound writes. 
> Let's see how this version fares.

Thank you I will place this in my for-testing branch shortly and see how
it fares.

Eric
