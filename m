From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Tue, 4 Mar 2008 19:24:36 -0600
Message-ID: <20080304192436.5690bc0e.pj@sgi.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	<47C7EEAC.7010907@amln.net>
	<47CBA787.8020100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935751AbYCEBY7@vger.kernel.org>
In-Reply-To: <47CBA787.8020100@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: xpl@amln.net, menage@google.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org, akpm@linux-foundation.org
List-Id: containers.vger.kernel.org

Paul M wrote (quoted by Li Zefan):
>> A compromise might be to keep "tasks" unprefixed, and say that future
>> names get the "cgroup." prefix; 

Another stray idea, for the master of stray ideas ;), how about (1) renaming
all the cgroup files as you like, Paul M, even including tasks to cgroup.tasks
or whatever, and then (2) adding symlinks for the legacy names, such as:

    tasks -> cgroup.tasks

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214
