From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Wed, 26 Nov 2008 09:44:39 -0800
Message-ID: <20081126174439.GA427@us.ibm.com>
References: <20081115212133.GA32140@us.ibm.com> <20081118175336.GA14178@redhat.com> <20081119012207.GA19092@us.ibm.com> <20081123231014.GA2424@redhat.com> <20081126031619.GA19756@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754409AbYKZRp3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081126031619.GA19756@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

| |    Actually, I think this is enough to solve most problems,
| |    the further changes can be discussed later. OK, the only
| |    "real" problem is SIGSTOP, afaics. This looks solveable.
| 
| Yes, SIGSTOP even from parent is ignored due to the SIGNAL_UNKILLABLE
| check in get_signal_to_deliver.

Actually with sig_task_ignored() patch, http://lkml.org/lkml/2008/11/18/251
SIGSTOP gets dropped early. To eventually allow SIGSTOP from ancestor ns,
we need to pass 'from_ancestor_ns' into sig_ignored() ?
