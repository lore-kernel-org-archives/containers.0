From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm] cgroup: fix boot option parsing
Date: Mon, 17 Mar 2008 16:26:57 +0800
Message-ID: <6599ad830803170126g3f886cb6l94462c52dcf0a03a@mail.gmail.com>
References: <47DE2AD9.503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755963AbYCQI1U@vger.kernel.org>
In-Reply-To: <47DE2AD9.503@cn.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 17, 2008 at 4:24 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> When boot with 'cgroup_disable=cpuacct', it turns out subsystem
>  'cpu' is disabled.
>
>  When Balbir posted the patch to add cgroup boot option support,
>  Paul M noticed this problem, but the patch was accepted without
>  fixing it.
>
>  Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

>  ---
>   kernel/cgroup.c |   15 ++++++---------
>   1 files changed, 6 insertions(+), 9 deletions(-)
>
>  diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>  index e8e8ec4..54c28ea 100644
>  --- a/kernel/cgroup.c
>  +++ b/kernel/cgroup.c
>  @@ -3062,25 +3062,22 @@ static void cgroup_release_agent(struct work_struct *work)
>   static int __init cgroup_disable(char *str)
>   {
>         int i;
>  +       char *token;
>  +
>  +       while ((token = strsep(&str, ",")) != NULL) {
>  +               if (!*token)
>  +                       continue;
>
>  -       while (*str) {
>                 for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>                         struct cgroup_subsys *ss = subsys[i];
>
>  -                       if (!strncmp(str, ss->name, strlen(ss->name))) {
>  +                       if (!strcmp(token, ss->name)) {
>                                 ss->disabled = 1;
>                                 printk(KERN_INFO "Disabling %s control group"
>                                         " subsystem\n", ss->name);
>                                 break;
>                         }
>                 }
>  -               /*
>  -                * Find the next option if any
>  -                */
>  -               while (*str && (*str != ','))
>  -                       str++;
>  -               if (*str == ',')
>  -                       str++;
>         }
>         return 1;
>   }
>  --
>  1.5.4.rc3
>
