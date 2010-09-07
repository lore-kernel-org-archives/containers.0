From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] cgroup : make the mount options parsing more accurate
Date: Tue, 7 Sep 2010 12:38:54 -0700
Message-ID: <AANLkTi=2qWKXGBsqmbZjUs_H2VSDykheAABha079puT3@mail.gmail.com>
References: <1283585466-30265-1-git-send-email-daniel.lezcano@free.fr>
	<1283585466-30265-2-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1283585466-30265-2-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Sep 4, 2010 at 12:31 AM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wr=
ote:
> The actual code does not detect 'all' with one subsystem name, which
> is IMHO mutually exclusive and when an option is specified even if it
> is not a subsystem name, we have to specify the 'all' option with the
> other option.
> eg:
> =A0not detected : mount -t cgroup -o all,freezer cgroup /cgroup
> =A0not flexible : mount -t cgroup -o noprefix,all cgroup /cgroup
>
> This patch fix this and makes the code a bit more clear by replacing
> 'else if' indentation by 'continue' blocks in the loop.

Can you fix this description to be clearer about the new behaviour of the c=
ode?

Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
