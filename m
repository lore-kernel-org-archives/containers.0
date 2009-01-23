From: Paul Menage <menage@google.com>
Subject: Re: [PATCH] cgroup: Fix root_count when mount fails due to busy
	subsystem
Date: Fri, 23 Jan 2009 10:42:44 -0800
Message-ID: <6599ad830901231042w69555fdfi5a033c0856a55824@mail.gmail.com>
References: <20090123004703.25103.29754.stgit@menage.corp.google.com>
	 <20090123181056.GA31142@elte.hu>
	 <6599ad830901231032h76a301ceica371145eca30388@mail.gmail.com>
	 <20090123183653.GC5984@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760436AbZAWSnB@vger.kernel.org>
In-Reply-To: <20090123183653.GC5984@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: akpm@linux-foundation.org, serue@us.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Fri, Jan 23, 2009 at 10:36 AM, Ingo Molnar <mingo@elte.hu> wrote:
>>
>> It's via the call to deactivate_super().
>
> Which exact call chain is that?

cgroup_get_sb() -> *failure* -> deactivate_super() -> VFS stuff
(sorry, no access to a source tree right now) -> cgroup_kill_sb()

Paul
