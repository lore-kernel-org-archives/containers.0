From: Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Propose] Isolate core_pattern in mnt namespace.
Date: Sun, 20 Dec 2015 10:47:50 +0800
Message-ID: <567616D6.6060202__29933.4795600318$1450580164$gmane$org@cn.fujitsu.com>
References: <56729B3D.1040502@cn.fujitsu.com> <56760F05.3020308@cn.fujitsu.com>
	<20151220023712.GT20997@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20151220023712.GT20997-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/20/2015 10:37 AM, Al Viro wrote:
> On Sun, Dec 20, 2015 at 10:14:29AM +0800, Dongsheng Yang wrote:
>> On 12/17/2015 07:23 PM, Dongsheng Yang wrote:
>>> Hi guys,
>>>      We are working on making core dump behaviour isolated in
>>> container. But the problem is, the /proc/sys/kernel/core_pattern
>>> is a kernel wide setting, not belongs to a container.
>>>
>>>      So we want to add core_pattern into mnt namespace. What
>>> do you think about it?
>>
>> Hi Eric,
>> 	I found your patch about "net: Implement the per network namespace
>> sysctl infrastructure", I want to do the similar thing
>> in mnt namespace. Is that suggested way?
>
> Why mnt namespace and not something else?

Hi Al,

Well, because core_pattern indicates the path to store core file.
In different mnt namespace, we would like to change the path with
different value.

In addition, Let's considering other namespaces:
UTS ns: contains informations of kernel and arch, not proper for 
core_pattern.
IPC ns: communication informations, not proper for core_pattern
PID ns: core_pattern is not related with pid
net ns: obviousely no.
user ns: not proper too.

Then I believe it's better to do this in mnt namespace. of course,
core_pattern is just one example. After this infrastructure finished,
we can implement more sysctls as per-mnt if necessary, I think.

Al, what do you think about this idea?

Yang
>
>
> .
>
