From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/1][V3] Add reboot_pid_ns to handle the reboot syscall
Date: Mon, 05 Dec 2011 22:17:34 +0100
Message-ID: <4EDD34EE.90704@free.fr>
References: <1323030290-22216-1-git-send-email-daniel.lezcano@free.fr>
	<1323030290-22216-2-git-send-email-daniel.lezcano@free.fr>
	<20111205204238.GA7422@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111205204238.GA7422-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/05/2011 09:42 PM, Oleg Nesterov wrote:
> On 12/04, Daniel Lezcano wrote:
>> This patch propose to store the reboot value in the 16 upper bits of the
>> exit code from the processes belonging to a pid namespace which has
>> rebooted. When the reboot syscall is called and we are not in the initial
>> pid namespace, we kill the pid namespace.
>>
>> By this way the parent process of the child pid namespace to know if
>> it rebooted or not and take the right decision.
>>
>> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
>> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> ---
>>  include/linux/pid_namespace.h |    8 +++++++-
>>  kernel/pid_namespace.c        |   33 +++++++++++++++++++++++++++++++++
>>  kernel/sys.c                  |    3 +++
>>  3 files changed, 43 insertions(+), 1 deletions(-)
> Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Andrew, do you think it's possible to take this patch upstream ?

Thanks
  -- Daniel
