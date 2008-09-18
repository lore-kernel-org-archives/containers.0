From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: Write Error: No space left on device
Date: Wed, 17 Sep 2008 17:40:56 -0700
Message-ID: <6599ad830809171740t2cbb459dqc273f240b9877ed8@mail.gmail.com>
References: <c7704c490809050541v2df520f9ja9edc4582ee1199f@mail.gmail.com>
	<20080905080008.bf9748ab.pj@sgi.com>
	<c7704c490809150455r3376db54g8d37aba6670500a9@mail.gmail.com>
	<6599ad830809151726t4ff6082dsfda259dccd503415@mail.gmail.com>
	<c7704c490809170557o21330ceaoeca5193add14c6d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c7704c490809170557o21330ceaoeca5193add14c6d4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 17, 2008 at 5:57 AM, Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> a)Definition of cpu.shares?
>    the default value is 1024. What is the max?

See Documentation/scheduler/sched-design-CFS.txt

> b) What is the relation between cpuset.cpu* values and cpu cgroup?

None.

> c) What is the relation between cpuset.mem* values and memory cgroup?

None.

Paul
