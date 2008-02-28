From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 13:28:31 -0800
Message-ID: <6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	 <20080228132142.4d4b1eef.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764307AbYB1V2v@vger.kernel.org>
In-Reply-To: <20080228132142.4d4b1eef.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org, pj@sgi.com
List-Id: containers.vger.kernel.org

On Thu, Feb 28, 2008 at 1:21 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:

>
>  Because if something is in /foo/bar/cgroup/notify_on_release then
>  prefixing the filename with "cgroup_" seems pretty pointless.
>

The point would be to avoid situations where a user has code that
creates a group directory called "foo", and then in a future kernel
release cgroups introduces a control file called "foo". If it's
prefixed, then the user just has to avoid creating groups prefixed by
"cgroup." or any subsystem name, so collisions will be less likely.

Paul
