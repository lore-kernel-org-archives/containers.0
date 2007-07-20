From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 02/10] Task Containers(V11): Add tasks file interface
Date: Fri, 20 Jul 2007 14:25:41 -0700
Message-ID: <6599ad830707201425u4c91965bq14e9dce10a1fb4a4@mail.gmail.com>
References: <20070720183152.637820000@menage.corp.google.com>
	 <20070720191247.556709000@menage.corp.google.com>
	 <Line.LNX.4.64.0707201616240.9702@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762309AbXGTV0Y@vger.kernel.org>
In-Reply-To: <Line.LNX.4.64.0707201616240.9702@d.namei>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: James Morris <jmorris@namei.org>
Cc: akpm@linux-foundation.org, dev@sw.ru, xemul@sw.ru, serue@us.ibm.com, vatsa@in.ibm.com, ebiederm@xmission.com, haveblue@us.ibm.com, svaidy@linux.vnet.ibm.com, balbir@in.ibm.com, pj@sgi.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, rohitseth@google.com, mbligh@google.com, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

On 7/20/07, James Morris <jmorris@namei.org> wrote:
> > +             if ((current->euid) && (current->euid != tsk->uid)
> > +                 && (current->euid != tsk->suid)) {
> > +                     put_task_struct(tsk);
> > +                     return -EACCES;
>
> I wonder if we should allow CAP_SYS_ADMIN to do this, too.
>

Yes, I ought to replace "current->euid" with "capable(CAP_SYS_ADMIN)".

Thanks,

Paul
