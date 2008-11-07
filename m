From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task
 directories
Date: Thu, 6 Nov 2008 17:25:21 -0800
Message-ID: <20081106172521.91061dcf.akpm@linux-foundation.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754717AbYKGB0V@vger.kernel.org>
In-Reply-To: <m1abcd2kqk.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, 06 Nov 2008 02:48:35 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> This is a genearl mechanism that is capable of removing
> any unused mounts on /proc in any directory.  As we flush
> the mounts when a processes dies this mechanism is tailored
> for flushing mounts in the per task and per task group
> directories.

What I'm missing here is any sense of what these patches are for,
where they're headed, what the big picture is, etc?

My vague guess is that perhaps it has something to do with mounting
procfs multiple times in separate containers.  How did I do?
