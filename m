From: Balaji Rao <balajirrao@gmail.com>
Subject: [RFC][-mm] [0/2] Basic stats for cgroups
Date: Wed, 26 Mar 2008 23:48:40 +0530
Message-ID: <200803262348.40928.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761788AbYCZSY4@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: containers@lists.osdl.org, dhaval@linux.vnet.ibm.com, balbir@in.ibm.comcontainers@lists.osdl.org, menage@google.com, a.p.zijlstra@chello.nl
List-Id: containers.vger.kernel.org

Hello,

This patchset is a first step towards implementing stats for cgroup 
subsystems. Only a few trivial stats for cpu and memory resource controller 
have been implemented for now. Please provide comments on the general 
direction and any suggestions on how you would like the cgroupstats framework 
to be implemented.

roadmap
--------
implement a generic statistics framework for cgroups,
unification with taskstats/netlink interface,
add more statistics 

-- 
regards,
balaji rao
