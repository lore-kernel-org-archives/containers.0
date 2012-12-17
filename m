From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 0/4] user namespace fixes
Date: Mon, 17 Dec 2012 11:03:10 -0800
Message-ID: <CALCETrX2Fa-DuM+wkgsij7oiJXzCD8W6Phkv-MjgCDg_Ma6CTg@mail.gmail.com>
References: <87txroxpgq.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87txroxpgq.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 14, 2012 at 2:01 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> These are fixes from Andys review of my user namespace tree.
>
> The first two patches are critical must fix fixes.
>
> The third patch fixing commit_creds is a nice to have but fixing it
> would be good.
>
> Andy, Serge  if you could give these patches a once over to make certain
> I am not doing something stupid.
>
> Thank you,
> Eric
>
> ---
>
> Eric W. Biederman (4):
>       Fix cap_capable to only allow owners in the parent user namespace to have caps.

For whatever reason, I didn't get the actual email.  Assuming this is
5e4a08476b50fa39210fca82e03325cc46b9c235:

Acked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>

However, this comment:
                /*
                 * The owner of the user namespace in the parent of the
                 * user namespace has all caps.
                 */
could use work.  I agree with the code, but I gave up on understanding
the comment.

>       userns:  Require CAP_SYS_ADMIN for most uses of setns.
>       userns: Add a more complete capability subset test to commit_creds
>       userns: Fix typo in description of the limitation of userns_install
>

--Andy
