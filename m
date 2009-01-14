From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Tue, 13 Jan 2009 18:50:29 -0800
Message-ID: <6599ad830901131850y508bbbbcr1560d762ed53d214@mail.gmail.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>
	 <496476FD.8090209@cn.fujitsu.com>
	 <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
	 <49682921.4020100@cn.fujitsu.com>
	 <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>
	 <496AA8E0.2070002@cn.fujitsu.com>
	 <6599ad830901131807n3acf6936g2028fc5f7edd6264@mail.gmail.com>
	 <496D524E.6050706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <496D524E.6050706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, Jan 13, 2009 at 6:47 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> - we put extra burden on subsystem developers.

Better than putting extra burden on cgroup_lock() :-)

Anyway, if this turns out to be a common operation, we can provide
support for it in the framework rather than having each subsystem
duplicate the effort.

Paul
