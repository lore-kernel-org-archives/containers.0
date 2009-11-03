From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 2/3] Fix the 'current css_set' problem in debug subsystem
Date: Mon, 2 Nov 2009 17:23:31 -0800
Message-ID: <6599ad830911021723t77583792q1a22c345d3b0d3c1@mail.gmail.com>
References: <b741c2440911012346k7213befcida229606f10c0399@mail.gmail.com>
	 <4AEF81E2.3060403@cn.fujitsu.com>
	 <b741c2440911021721o610ee4f1la123146e6e503d2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757592AbZKCBXd@vger.kernel.org>
In-Reply-To: <b741c2440911021721o610ee4f1la123146e6e503d2d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Liu Aleaxander <aleaxander@gmail.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Mon, Nov 2, 2009 at 5:21 PM, Liu Aleaxander <aleaxander@gmail.com> wrote:
> Yes, I know it means 'current task', but is this useful to print the
> same things with two more files in all the cgroups?
>

We could just export those files in the root cgroup in the debug hierarchy.

Paul
