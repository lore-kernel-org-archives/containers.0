From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v8)
Date: Mon, 10 Aug 2009 16:02:35 -0500
Message-ID: <20090810210235.GB24373@us.ibm.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com> <1249918379-29414-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1249918379-29414-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports socketpair()s, path-based, and
> abstract sockets.

Thanks, Dan.  Apart from the double-free on error case in
sock_copy_buffers(), this looks very good to me.  So with that
change, please feel free to add:

Acked-by: Serge Hallyn <serue@us.ibm.com>

Oren, pls do consider pulling this into v18.

Dan, do you have any testcases (even just descriptions of
how to test, which i'll then try to script) i can add to
cr_tests?

thanks,
-serge
