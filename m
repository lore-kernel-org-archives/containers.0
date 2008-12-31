From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 3/6][v5] Define siginfo_from_ancestor_ns()
Date: Tue, 30 Dec 2008 16:12:55 -0800 (PST)
Message-ID: <20081231001255.86B98FC278@magilla.sf.frob.com>
References: <20081227204658.GA27197@us.ibm.com>
	<20081227205222.GB27337@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753016AbYLaANu@vger.kernel.org>
In-Reply-To: Sukadev Bhattiprolu's message of  Saturday, 27 December 2008 12:52:22 -0800 <20081227205222.GB27337@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Drop the second hunk of the patch (stray whitespace change).

The treatment of SI_ASYNCIO is wrong, as I described in an earlier posting.
(It is indeed a user-generated signal.)  You'll need to avoid using this
function in the path from the USB driver case (interrupt level), since you
can't use SI_ASYNCIO to avoid unsafe use of pid_ns data structures.  If you
do as I suggested in that posting, this is no problem since you just never
do this check in the kill_pid_info_as_uid (perhaps renamed) case.


Thanks,
Roland
