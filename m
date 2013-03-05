From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/2] fs: Limit sys_mount to only request filesystem
	modules.
Date: Tue, 05 Mar 2013 15:24:11 -0800
Message-ID: <87boax8m78.fsf@xmission.com>
References: <CAGXu5jK7x+gFKgCN5=ZF+kSc4xSNbGtSERHCoOnCEgiJ1_wNGg@mail.gmail.com>
	<20130303005700.GA32213@austin.hallyn.com>
	<874ngtxgt5.fsf@xmission.com>
	<CAGXu5j+bwUx6r++ttvYg4yJrUUHxoQ86tQ0JzEBoQQU6KAh9ww@mail.gmail.com>
	<874ngsrvrh.fsf@xmission.com>
	<CAGXu5jJiO=BmjVbpVJhxHbafn5T_SQbe5g-RLxRbmknNnQMyfQ@mail.gmail.com>
	<87k3pnmwpk.fsf_-_@xmission.com> <878v63mwm3.fsf_-_@xmission.com>
	<CAPXgP11AB7=2oeXtxb0so4a8hms7-_UWJDVE=6kndU062tGycQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAPXgP11AB7=2oeXtxb0so4a8hms7-_UWJDVE=6kndU062tGycQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Kay Sievers's message of "Tue, 5 Mar 2013 20:06:45 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Cc: Brad Spengler <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Kay Sievers <kay-tD+1rO4QERM@public.gmane.org> writes:

> On Mon, Mar 4, 2013 at 8:51 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> Modify the request_module to prefix the file system type with "fs-"
>> and add aliases to all of the filesystems that can be built as modules
>> to match.
>>
>> A common practice is to build all of the kernel code and leave code
>> that is not commonly needed as modules, with the result that many
>> users are exposed to any bug anywhere in the kernel.
>>
>> Looking for filesystems with a fs- prefix limits the pool of possible
>> modules that can be loaded by mount to just filesystems trivially
>> making things safer with no real cost.
>
> '-' is a commonly used part of a module name, and does not mix well
> with ramdom user provided names.

The symbols '-' and '_' occur in 2382 out of 3968 modules from an
allmodconfig build, and modprobe ignores the difference between the two.
However only three of those modules begin with fs and none of them begin
with fs-.

Furthermore if it actually becomes a concern to ensure we are talking
about an alias rather than a real module name, the solution is to
change how we call modprobe.  As long as we are in the same namespace
something can go wrong.

fs- seems sufficiently unique for the purpose.

> We usually use ':' as the prefix separator for modaliases, when
> user-supplied strings are prefixed with the subsystem.

There are at least two different conventions in use.  For software
subsystems like the networking stack '-' is the commonly used
to separate the prefix.  For hardware specific subsystems ':' is
commonly used.  What I really don't want to load here are hardware
modules so using a hardware module style convention does not seem like
the right way to go.

> I think it would be nicer to change that, and I'm sure some creative
> guy calls the next filesystem of the month fs-$something :)

If it is a filesystem it simply does not matter.  The goal is to
only load filesystems.

If it is not a filesystem someone has choosen a confusing naming
convention.

If it turns out I am wrong it is a two line change.

Eric
