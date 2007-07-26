From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/2] refaults
Date: Thu, 26 Jul 2007 19:25:04 +0200
Message-ID: <20070726172504.415412586@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932567AbXGZR2i@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, riel@redhat.com, a.p.zijlstra@chello.nl
List-Id: containers.vger.kernel.org

Hi,

This is a brush up of the refault patches, as presented by Rik at last
year's OLS:

  http://people.redhat.com/riel/riel-OLS2006.pdf

When talking to people at OLS this year there was a renewed interrest in
the concept.
