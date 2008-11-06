From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] freezer_cg: disable writing freezer.state of root
	cgroup
Date: Wed, 5 Nov 2008 16:48:26 -0800
Message-ID: <6599ad830811051648i72c2c585s4ee803e030c798ad__39054.0124536075$1225932930$gmane$org@mail.gmail.com>
References: <20080811235323.872291138@us.ibm.com>
	<20080811235325.121356317@us.ibm.com>
	<6599ad830811032143h51eae533k5b0c17e65a7fa675@mail.gmail.com>
	<490FE7B5.8020400@cn.fujitsu.com>
	<6599ad830811032240n640f3fao48f1a9f05892b797@mail.gmail.com>
	<490FFB56.7030300@cn.fujitsu.com>
	<6599ad830811032356g6827a97dq41dec492fed8de15@mail.gmail.com>
	<4910014F.4000808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4910014F.4000808-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 4, 2008 at 12:01 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Paul Menage wrote:
>> On Mon, Nov 3, 2008 at 11:35 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> With this change, the root cgroup is unfreezable, and writing to
>>> its freezer.state returns -EIO.
>>
>> EINVAL might be more consistent with other systems like cpusets.
>>
>
> Because writing FREEZE (or other invalid value) to freezer.state returns EIO..
>
> Or that EIO should be also changed to EINVAL.

Yes, I think that should be EINVAL too - seems more consistent.

Paul
