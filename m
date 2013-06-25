From: BRULE Herman <brule.herman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: cgroup with correct cpu time
Date: Tue, 25 Jun 2013 12:07:32 +0200
Message-ID: <CAPH+pffwRR0touOGmSR_pSiwTkorMNvBmJCnob6rko7M4bzekA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

I have well added into my vserver flag (container based on cgroup):
VIRT_MEM (munin memory script is buggy, I think due to not correct memory
repported by cgroup)
VIRT_UPTIME
VIRT_CPU
VIRT_LOAD
Load, memory, uptime mostly work as execepted. But the cpu time no, the
time into the guest (cgroup) is same as all the (host) machine. I need only
display the cpu time of the cgroup (by all tool: top, htop, munin, ...),
question of work and security.
This features/fix can be paid.

Cheer,

-- 
BRULE Herman <brule.herman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Main developer of Ultracopier, Esourcing and server management
IT, OS, technologies, security and business department
