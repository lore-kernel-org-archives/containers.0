From: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] fs: Limit sys_mount to only request filesystem
	modules.
Date: Tue, 5 Mar 2013 11:32:00 -0800
Message-ID: <CAGXu5j+ygnVMynwKHBzfaPT=vx4vCka5RcBpyX+BHvSMokV8ow@mail.gmail.com>
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
Cc: Brad Spengler <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 5, 2013 at 11:06 AM, Kay Sievers <kay-tD+1rO4QERM@public.gmane.org> wrote:
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
>
> We usually use ':' as the prefix separator for modaliases, when
> user-supplied strings are prefixed with the subsystem.
>
> I think it would be nicer to change that, and I'm sure some creative
> guy calls the next filesystem of the month fs-$something :)

The precedent is "-". "netdev-" "pf-net-" etc. Naming something
fs-$something is fine as long as it's actually a filesystem. :)

-Kees

-- 
Kees Cook
Chrome OS Security
