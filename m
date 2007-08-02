From: Roland McGrath <roland@redhat.com>
Subject: Re: [RFC, PATCH] handle the multi-threaded init's exit() properly
Date: Thu,  2 Aug 2007 15:51:27 -0700 (PDT)
Message-ID: <20070802225127.3EC214D04B5@magilla.localdomain>
References: <20070802212009.GA516@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759513AbXHBWvt@vger.kernel.org>
In-Reply-To: Oleg Nesterov's message of  Friday, 3 August 2007 01:20:09 +0400 <20070802212009.GA516@tv-sign.ru>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

This looks fine to me, though I don't know anything about the nsproxy bit.
Now that choose_new_parent is one trivial line, you might go on to get rid
of it and roll its one line into reparent_thread.


Thanks,
Roland
