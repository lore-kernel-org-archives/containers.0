From: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Subject: Re: [RFC 0/4] reduce pid_namespace footprint when not configured
Date: Wed, 30 Sep 2015 23:34:02 +0200
Message-ID: <87r3lfegmt.fsf@rasmusvillemoes.dk>
References: <1443646163-31316-1-git-send-email-linux@rasmusvillemoes.dk>
	<87zj03ei64.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87zj03ei64.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Wed, 30 Sep 2015 16:00:51 -0500")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 30 2015, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:

> Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org> writes:
>
>> A few suggestions for reducing the footprint of pid namespaces when
>> CONFIG_PID_NS=n. The savings are admittedly not huge:
>>
>> $ scripts/bloat-o-meter /tmp/vmlinux.master vmlinux
>> add/remove: 0/7 grow/shrink: 30/25 up/down: 368/-1032 (-664)
>
> #ifdefs in C files.
> More code to maintain.
> Very minor savings.
>
> I don't think it is worth the pain.  If anything I would prefer to
> remove CONFIG_PID_NS.  The CONFIG_PID_NS ifdef really is about keeping
> from exposing people to the feature tha don't use it more than it is
> about size reduction.
>
> Or do you have a case where this makes the difference between a usable
> kernel and a kernel that is not?

No, it was mostly a small tinification effort, and we'd presumably also
save a few cycles on thread creation, but not anything measurable.

Rasmus
