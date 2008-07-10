From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/5] Resend -v2 - Use procfs to change a syscall
	behavior
Date: Wed, 09 Jul 2008 17:36:46 -0700
Message-ID: <m1lk0aefs1.fsf@frodo.ebiederm.org>
References: <20080708112422.164370000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080708112422.164370000-6ktuUTfB/bM@public.gmane.org> (Nadia Derbey's message of
	"Tue, 08 Jul 2008 13:24:22 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Nadia.Derbey-6ktuUTfB/bM@public.gmane.org writes:

> This patchset is a part of an effort to change some syscalls behavior for
> checkpoint restart.

Thanks for doing this.

Unfortunately this makes a very good case of why we don't want to go down
this route.  Adding magic parameters to syscalls that are only useful
in one very specific restart case.

We need good clean interfaces with well defined semantics.

Something as narrow focused on this is not really useful and it takes
a lot of code to do something very few people will want to actively
do.

> The syntax is:
> # echo "LONG1 XX" > /proc/self/task/<my_tid>/next_syscall_data
>      next object to be created will have an id set to XX

Which his horrible in another way because it is hugely race prone.

Eric
