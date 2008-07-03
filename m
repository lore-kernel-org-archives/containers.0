From: "Paul Menage" <menage@google.com>
Subject: Re: Attaching PID 0 to a cgroup
Date: Thu, 3 Jul 2008 15:03:05 -0700
Message-ID: <6599ad830807031503s6c7f3d5fu3bf65d5a944f5c17@mail.gmail.com>
References: <20080701094545.GD3925@linux.vnet.ibm.com>
	 <20080701094734.GE3925@linux.vnet.ibm.com>
	 <486A06B7.7020906@cn.fujitsu.com> <486AA62F.40503@gmail.com>
	 <20080701215448.GD5893@linux.vnet.ibm.com>
	 <1215122375.14808.180.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755895AbYGCWDd@vger.kernel.org>
In-Reply-To: <1215122375.14808.180.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, lkml <linux-kernel@vger.kernel.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 3, 2008 at 2:59 PM, Matt Helsley <matthltc@us.ibm.com> wrote:
> ------------
>        char buffer[16];
>        int fd;
>
>        fd = open("/some/cgroup/tasks", O_WRONLY);
>
>        /*
>         * These two writes produce the same effect: adding this process
>         * to /some/cgroup.
>         */
>        if (the_slightly_shorter_way)
>                write(fd, "0", 2);
>        else {
>                /* The slightly-less-short way */
>                snprintf(buffer, 16, "%u", getpid());
>                write(fd, buffer, strlen(buffer));

If it's a threaded application, then you'd need gettid() rather than
getpid() for the two to be equivalent.

Paul
